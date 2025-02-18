using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150EmpWorkDetail
{
    public decimal WorkTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal PrjId { get; set; }

    public decimal WorkId { get; set; }

    public DateTime TimeFrom { get; set; }

    public DateTime TimeTo { get; set; }

    public decimal Duration { get; set; }

    public DateTime WorkDate { get; set; }

    public string? Description { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040ProjectMaster Prj { get; set; } = null!;

    public virtual T0040WorkMaster Work { get; set; } = null!;
}
