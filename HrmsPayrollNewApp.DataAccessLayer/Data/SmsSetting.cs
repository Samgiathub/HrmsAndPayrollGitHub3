using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SmsSetting
{
    public int SmsId { get; set; }

    public bool? SendSms { get; set; }

    public string? SmsUrl { get; set; }

    public string Urldata { get; set; } = null!;

    public string? UserName { get; set; }

    public string? Password { get; set; }

    public string? ApiKey { get; set; }

    public string? SenderId { get; set; }

    public string? MsgType { get; set; }

    public string? Response { get; set; }

    public string? HeaderId { get; set; }

    public string? EntityId { get; set; }

    public string? TempId { get; set; }

    public string? Message { get; set; }
}
