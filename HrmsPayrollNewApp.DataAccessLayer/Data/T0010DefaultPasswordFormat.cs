using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0010DefaultPasswordFormat
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? PwdType { get; set; }

    public string? PwdFormat { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? SysDate { get; set; }

    public string? IpAddress { get; set; }
}
