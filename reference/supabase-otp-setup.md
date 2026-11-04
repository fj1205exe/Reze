# Supabase OTP Email Setup

## Step 1: Enable OTP in Auth Settings

Go to **Authentication > Providers > Email** in the Supabase dashboard.

Make sure:
- **Enable Email provider** is ON
- **Confirm email** is ON
- **Enable email OTP** is ON (if available as separate toggle)

## Step 2: Update the Magic Link Email Template

Go to **Authentication > Email Templates > Magic Link**.

Replace the entire template body with the HTML below.

### Subject line:
```
Your MLab verification code
```

### Template body:
```html
<div style="background-color: #0B0D10; padding: 40px 20px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
  <div style="max-width: 400px; margin: 0 auto; background-color: #14171C; border-radius: 16px; padding: 40px 32px; border: 1px solid rgba(255,255,255,0.06);">
    <div style="text-align: center; margin-bottom: 32px;">
      <div style="display: inline-block; width: 48px; height: 48px; border-radius: 14px; background: linear-gradient(135deg, #8B5CF6, #6D28D9); line-height: 48px; text-align: center;">
        <span style="color: white; font-size: 24px; font-weight: 700; font-family: 'Space Grotesk', sans-serif;">M</span>
      </div>
      <h1 style="color: #F5F7FA; font-size: 22px; font-weight: 700; margin: 16px 0 4px 0; font-family: 'Space Grotesk', sans-serif;">Welcome to MLab</h1>
      <p style="color: #9CA3AF; font-size: 14px; margin: 0;">Enter this code in the app to verify your email.</p>
    </div>

    <div style="background-color: #0B0D10; border-radius: 12px; padding: 24px; text-align: center; margin-bottom: 24px; border: 1px solid rgba(255,255,255,0.06);">
      <p style="color: #9CA3AF; font-size: 12px; margin: 0 0 8px 0; letter-spacing: 0.05em;">YOUR VERIFICATION CODE</p>
      <p style="color: #F5F7FA; font-size: 36px; font-weight: 700; margin: 0; letter-spacing: 8px; font-family: 'SF Mono', 'Fira Code', monospace;">{{ .Token }}</p>
    </div>

    <p style="color: #9CA3AF; font-size: 13px; text-align: center; margin: 0;">
      This code expires in 10 minutes.<br>
      If you did not request this, ignore this email.
    </p>
  </div>

  <p style="color: #4B5563; font-size: 11px; text-align: center; margin-top: 24px;">
    MLab — Learn ML by playing with the math.
  </p>
</div>
```

## Step 3: Test It

1. Open the app
2. Tap "Sign in or create account"
3. Switch to "Create account" tab
4. Enter your email
5. Tap "Send verification code"
6. Check your inbox for the branded MLab email
7. Enter the 6-digit code in the app
8. Set your display name and password

## Notes

- `{{ .Token }}` is the Supabase template variable for the OTP code
- The email is dark-themed to match the app
- No magic link is included — code-only entry
- The code expires in 10 minutes (Supabase default, configurable in Auth settings)
