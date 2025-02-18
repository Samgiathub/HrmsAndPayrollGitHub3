using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095LeaveOpening
{
    public decimal LeaveOpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal GrdId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LeaveOpDays { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040GradeMaster Grd { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;
}
