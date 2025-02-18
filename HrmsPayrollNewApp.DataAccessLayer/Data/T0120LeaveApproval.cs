using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120LeaveApproval
{
    public decimal LeaveApprovalId { get; set; }

    public decimal? LeaveApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public string ApprovalComments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public byte MCancelWoHo { get; set; }

    public byte IsBackdatedApp { get; set; }

    public byte? IsAutoLeaveFromSalary { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0100LeaveApplication? LeaveApplication { get; set; }

    public virtual T0080EmpMaster? SEmp { get; set; }

    public virtual ICollection<T0135LeaveCancelation> T0135LeaveCancelations { get; set; } = new List<T0135LeaveCancelation>();

    public virtual ICollection<T0210LwpConsideredSameSalaryCutoff> T0210LwpConsideredSameSalaryCutoffs { get; set; } = new List<T0210LwpConsideredSameSalaryCutoff>();
}
