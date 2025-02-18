using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100LeaveApplication
{
    public decimal LeaveApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApplicationDate { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public string ApplicationStatus { get; set; } = null!;

    public string ApplicationComments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public byte IsBackdatedApplication { get; set; }

    public byte IsResponsibilityPass { get; set; }

    public decimal? ResponsibleEmpId { get; set; }

    public byte MCancelWoHo { get; set; }

    public byte ApplyFromAttReg { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }

    public virtual ICollection<T0115LeaveLevelApproval> T0115LeaveLevelApprovals { get; set; } = new List<T0115LeaveLevelApproval>();

    public virtual ICollection<T0120LeaveApproval> T0120LeaveApprovals { get; set; } = new List<T0120LeaveApproval>();
}
