using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0010EmailSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string MailServer { get; set; } = null!;

    public decimal MailServerPort { get; set; }

    public string MailServerUserName { get; set; } = null!;

    public string MailServerPassword { get; set; } = null!;

    public byte Ssl { get; set; }

    public string MailServerDisplayName { get; set; } = null!;

    public string FromEmail { get; set; } = null!;

    public byte? IsMes { get; set; }

    public string? Mesuri { get; set; }

    public string? MesreplyTo { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal UserId { get; set; }

    public string ToEmail { get; set; } = null!;
}
