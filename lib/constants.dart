// This class holds constant values for the application
abstract class Constants {

  // Loading supabase credentials from enviornment
  static const String SUPABASE_URL = String.fromEnvironment('SUPABASE_URL');
  static const String SUPABASE_KEY = String.fromEnvironment('SUPABASE_KEY');
}
