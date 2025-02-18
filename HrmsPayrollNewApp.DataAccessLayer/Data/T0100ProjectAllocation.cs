using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100ProjectAllocation
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal PrjId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime EffDate { get; set; }

    public string? EmpActive { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040ProjectMaster Prj { get; set; } = null!;
}
