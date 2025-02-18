using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpLateDetail
{
    public decimal LMarkId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LateBalanceBf { get; set; }

    public decimal LateCurrDays { get; set; }

    public decimal LateTotalDays { get; set; }

    public decimal LateTobeAdjDays { get; set; }

    public decimal LateAdjDays { get; set; }

    public decimal LateClosing { get; set; }

    public decimal? LeaveId { get; set; }

    public decimal LateAdjAgnLeave { get; set; }

    public decimal LateTotalAdjDays { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LeaveMaster? Leave { get; set; }
}
