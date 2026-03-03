class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://salgnwxzcnwjdjozrhyt.supabase.co');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhbGdud3h6Y253amRqb3pyaHl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxNDA4MTgsImV4cCI6MjA4NzcxNjgxOH0.n13pUON2azZu_-lj7chVixfle12jzQa7ChS-LFNn7o8');
}
