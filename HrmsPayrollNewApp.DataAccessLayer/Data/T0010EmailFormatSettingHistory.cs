using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0010EmailFormatSettingHistory
{
    public decimal EmailTypeId { get; set; }

    public decimal CmpId { get; set; }

    public string? EmailType { get; set; }

    public string? EmailTitle { get; set; }

    public string? EmailSignature { get; set; }

    public string? EmailAttachment { get; set; }

    public string? Notes { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SysDate { get; set; }
}
