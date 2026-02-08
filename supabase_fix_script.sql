-- =============================================
-- HWW 社区模块修复脚本
-- 请在 Supabase SQL Editor 中执行此脚本
-- =============================================

-- 1. 创建 profiles 表（如果不存在）
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  username TEXT UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  points DECIMAL(18, 2) DEFAULT 1000,  -- 默认给1000积分用于测试
  tokens DECIMAL(18, 8) DEFAULT 0,
  did TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 创建索引
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_name ON profiles(name);

-- 3. 启用 RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 4. 删除现有策略（避免冲突）
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
DROP POLICY IF EXISTS "Users can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- 5. 创建 RLS 策略
-- 允许所有认证用户读取任何 profile（用于显示作者信息）
CREATE POLICY "Users can view all profiles" ON profiles
  FOR SELECT USING (true);

-- 用户可以插入自己的 profile
CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 用户可以更新自己的 profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- 6. 创建 updated_at 触发器函数
CREATE OR REPLACE FUNCTION update_profiles_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_profiles_timestamp ON profiles;
CREATE TRIGGER trigger_update_profiles_timestamp
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_profiles_timestamp();

-- 7. 创建自动创建 profile 的函数（新用户注册时）
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, username, avatar_url, points)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1) || '_' || substr(NEW.id::text, 1, 8)),
    NEW.raw_user_meta_data->>'avatar_url',
    1000  -- 新用户默认1000积分
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建新用户注册触发器
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- 8. 为现有用户创建 profile（如果不存在）
INSERT INTO profiles (id, name, username, points)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'name', raw_user_meta_data->>'full_name', split_part(email, '@', 1)),
  split_part(email, '@', 1) || '_' || substr(id::text, 1, 8),
  1000
FROM auth.users
WHERE id NOT IN (SELECT id FROM profiles)
ON CONFLICT (id) DO NOTHING;

-- 9. 确保 posts 表的 RLS 策略正确
DROP POLICY IF EXISTS "Public posts are viewable by everyone" ON posts;
DROP POLICY IF EXISTS "Users can create posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;

CREATE POLICY "Public posts are viewable by everyone" ON posts
  FOR SELECT USING (
    visibility = 'public' OR
    author_id = auth.uid() OR
    (visibility = 'followers' AND author_id IN (
      SELECT following_id FROM user_follows WHERE follower_id = auth.uid()
    ))
  );

CREATE POLICY "Users can create posts" ON posts
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL AND author_id = auth.uid());

CREATE POLICY "Users can update their own posts" ON posts
  FOR UPDATE USING (author_id = auth.uid());

CREATE POLICY "Users can delete their own posts" ON posts
  FOR DELETE USING (author_id = auth.uid());

-- 10. 确保 community_tasks 表的 RLS 策略正确
DROP POLICY IF EXISTS "Anyone can view open tasks" ON community_tasks;
DROP POLICY IF EXISTS "Users can create tasks" ON community_tasks;
DROP POLICY IF EXISTS "Authors can update their tasks" ON community_tasks;
DROP POLICY IF EXISTS "Authors can delete their tasks" ON community_tasks;

CREATE POLICY "Anyone can view open tasks" ON community_tasks
  FOR SELECT USING (
    status IN ('open', 'matching') OR
    author_id = auth.uid() OR
    assigned_to = auth.uid()
  );

CREATE POLICY "Users can create tasks" ON community_tasks
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL AND author_id = auth.uid());

CREATE POLICY "Authors can update their tasks" ON community_tasks
  FOR UPDATE USING (author_id = auth.uid());

CREATE POLICY "Authors can delete their tasks" ON community_tasks
  FOR DELETE USING (author_id = auth.uid() AND status = 'open');

-- 11. 验证修复结果
SELECT 'profiles 表记录数: ' || COUNT(*)::text FROM profiles;
SELECT 'posts 表记录数: ' || COUNT(*)::text FROM posts;
SELECT 'community_tasks 表记录数: ' || COUNT(*)::text FROM community_tasks;

-- 完成！
SELECT '修复脚本执行完成！' AS status;
