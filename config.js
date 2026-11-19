import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm";

/*
 * PesaAI uses the existing Garage Operations Supabase project.
 * The publishable/anon key is intended for browser use when RLS is enabled.
 * NEVER place a service_role key or AI provider secret in this file.
 */
export const APP_CONFIG = Object.freeze({
  name: "PesaAI",
  supabaseUrl: "https://ptluwoeogfkqavhspdjj.supabase.co",
  supabaseAnonKey: "sb_publishable_wDsWINauH0jX9rezsEwczw_RovrM6Nv",
  defaultCurrency: "KES"
});

export const supabase = createClient(
  APP_CONFIG.supabaseUrl,
  APP_CONFIG.supabaseAnonKey,
  {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true
    }
  }
);
