using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100LeaveCfDetail
{
    public decimal LeaveCfId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime? CfForDate { get; set; }

    public DateTime? CfFromDate { get; set; }

    public DateTime? CfToDate { get; set; }

    public decimal? CfPDays { get; set; }

    public decimal CfLeaveDays { get; set; }

    public string CfType { get; set; } = null!;

    public decimal? ExceedCfDays { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public byte IsFnf { get; set; }

    public decimal? CfLapsDays { get; set; }

    public decimal? AdvanceLeaveBalance { get; set; }

    public decimal? AdvanceLeaveRecoverBalance { get; set; }

    public DateTime? LastModifyDate { get; set; }

    public decimal? LastModifyBy { get; set; }

    public string? CfMode { get; set; }

    public bool? CfIsMakerChecker { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;
}
