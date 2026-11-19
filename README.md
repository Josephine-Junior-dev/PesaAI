# PesaAI

**Your Money. Your Business. Your Future.**

PesaAI is an AI-powered personal and business financial intelligence platform. Its product vision is to help individuals, families and entrepreneurs understand, protect, plan and grow their finances.

## Current foundation

- Supabase email/password registration and sign-in
- Password recovery email flow
- User profile and preferred currency
- Separate personal and business transaction spaces
- Income, expense and transfer-ready data model
- Dashboard totals and recent transactions
- Basic Financial Life Score (guidance only, not a credit score)
- Savings scenario calculator
- CSV export
- Responsive, installable PWA foundation

## Technology

- HTML, CSS and JavaScript modules
- Supabase Auth and Postgres
- Row Level Security on every user-owned table
- GitHub Pages hosting

## Setup

1. Run `supabase/pesaai_schema.sql` in the SQL Editor of the existing Garage Operations Supabase project.
2. Confirm the project URL and publishable key in `config.js`.
3. Enable Email/Password authentication in Supabase.
4. Configure the Supabase Auth Site URL and redirect URLs for your GitHub Pages address.
5. Enable GitHub Pages from the repository's `main` branch, root folder.

## Important security notes

- The browser uses only the Supabase publishable/anon key.
- Never put a Supabase service-role key or AI provider API key in frontend files.
- All PesaAI database tables use the `pa_` prefix and have user ownership RLS.
- AI features are intentionally marked as not yet connected until a secure server-side AI endpoint is deployed.
- Imported financial documents and bank connections require explicit user consent and secure processing.

## Product roadmap

1. Secure application foundation and separated personal/business records
2. Financial Life Score and transparent health breakdown
3. Dual Financial Twin and scenario simulations
4. Secure AI assistant grounded in user-authorised data
5. M-Pesa and statement import with duplicate detection
6. Family finance, financial guardian and recovery planning
7. Enterprise APIs, audit trails, tenant isolation and bank-ready security review

## Product principles

PesaAI is a financial information and planning tool. It does not guarantee investment returns, diagnose fraud with certainty, provide regulated investment advice, or make lending decisions.


## Real AI assistant setup (free provider)

The assistant analyses only the selected personal, business or combined records. A Supabase Edge Function verifies the signed-in user and reads data through that user's RLS policies. The AI secret is kept server-side.

1. Deploy `supabase/functions/pesaai-assistant/index.ts` from Supabase **Edge Functions**.
2. Add `GROQ_API_KEY` in Edge Function secrets using a free GroqCloud API key. This is not an OpenAI key; no paid OpenAI API key or compulsory OpenAI billing is required. Groq free usage has limits.
3. Ensure the standard `SUPABASE_URL` and `SUPABASE_ANON_KEY` Edge Function environment variables are available.
4. Redeploy the function, sign in, open **AI assistant**, choose the data scope and ask a question.

**Privacy:** Selected transaction descriptions, amounts, dates, currencies, budgets, savings goals and debts are sent to Groq for the response. Do not enter PINs, passwords or full account numbers. Review Groq's current data terms before using sensitive real financial data. Free limits can change or be exhausted; this is suitable for prototyping and early testing, not unlimited production. AI can make mistakes; verify important decisions.
