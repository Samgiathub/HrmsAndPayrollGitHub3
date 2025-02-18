using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115LeaveLevelApproval
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveApplicationId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal LeavePeriod { get; set; }

    public string LeaveAssignAs { get; set; } = null!;

    public string LeaveReason { get; set; } = null!;

    public byte MCancelWoHo { get; set; }

    public DateTime? HalfLeaveDate { get; set; }

    public decimal SEmpId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public string ApprovalComments { get; set; } = null!;

    public byte RptLevel { get; set; }

    public DateTime SystemDate { get; set; }

    public byte IsResponsibilityPass { get; set; }

    public decimal? ResponsibleEmpId { get; set; }

    public decimal IsArrear { get; set; }

    public decimal ArrearMonth { get; set; }

    public decimal ArrearYear { get; set; }

    public DateTime? LeaveOutTime { get; set; }

    public DateTime? LeaveInTime { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public byte HalfPayment { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;

    public virtual T0100LeaveApplication LeaveApplication { get; set; } = null!;
}
