using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0010GatePassSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal UptoDays { get; set; }

    public string? UptoHours { get; set; }

    public decimal DeductDays { get; set; }

    public string? AboveHours { get; set; }

    public decimal DeductAboveDays { get; set; }
}
