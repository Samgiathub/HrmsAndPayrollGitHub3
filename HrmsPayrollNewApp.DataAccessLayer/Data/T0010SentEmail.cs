using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0010SentEmail
{
    public decimal EmailDetailId { get; set; }

    public string FromEmail { get; set; } = null!;

    public string ToEmail { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal FromEmpId { get; set; }

    public string Subject { get; set; } = null!;

    public string Message { get; set; } = null!;

    public DateTime EmailDate { get; set; }

    public string EmailCc { get; set; } = null!;

    public string EmailBcc { get; set; } = null!;

    public string EmailStatus { get; set; } = null!;

    public string? IpAddress { get; set; }

    public string? Attachment { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
