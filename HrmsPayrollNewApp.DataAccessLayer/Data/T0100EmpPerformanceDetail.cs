using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpPerformanceDetail
{
    public decimal PerDetailId { get; set; }

    public decimal PerIncTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal Percentage { get; set; }

    public decimal OutOfPer { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SysDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040PerformanceIncentiveMaster PerIncTran { get; set; } = null!;
}
