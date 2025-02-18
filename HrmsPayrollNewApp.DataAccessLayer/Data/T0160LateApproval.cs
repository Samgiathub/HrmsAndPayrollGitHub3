using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0160LateApproval
{
    public decimal LateTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? TotalLate { get; set; }

    public decimal LateCalDay { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime? MonthDate { get; set; }

    /// <summary>
    /// L - late , E - Early , LE - Late n Early
    /// </summary>
    public string ApprovalType { get; set; } = null!;

    public decimal? LeaveBalance { get; set; }

    public decimal? TotalPenaltyDays { get; set; }

    public decimal PenaltyDaysToAdjust { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
