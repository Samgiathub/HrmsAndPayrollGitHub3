using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class EmailLog
{
    public int EmailLogsId { get; set; }

    public int CmpId { get; set; }

    public string? ModuleName { get; set; }

    public string? ToEmail { get; set; }

    public string? CcEmail { get; set; }

    public string? Sub { get; set; }

    public string? BodyEmail { get; set; }

    public DateTime? GenDate { get; set; }

    public string? ErrorEmail { get; set; }

    public string? AttachPath { get; set; }

    /// <summary>
    /// 1-send,2-resend,3-fail
    /// </summary>
    public int Status { get; set; }

    public string? FormName { get; set; }

    public byte SendMailJob { get; set; }

    public byte EmailSendFlag { get; set; }

    public DateTime? EmailSendDate { get; set; }
}
