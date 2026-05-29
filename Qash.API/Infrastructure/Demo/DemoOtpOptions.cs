namespace Qash.API.Infrastructure.Demo;

/// <summary>
/// University/demo OTP settings. Not for production — codes are returned in API
/// responses and matched against a fixed value instead of SMS/email.
/// Configure in appsettings under the "DemoOtp" section.
/// </summary>
public static class DemoOtpOptions
{
    public const string SectionName = "DemoOtp";

    public const string ConfigurationKey = "DemoOtp:VerificationCode";

    /// <summary>Default demo code when configuration is missing (5 digits).</summary>
    public const string DefaultVerificationCode = "00000";

    public static string GetVerificationCode(IConfiguration configuration)
    {
        return configuration[ConfigurationKey]?.Trim() ?? DefaultVerificationCode;
    }
}
