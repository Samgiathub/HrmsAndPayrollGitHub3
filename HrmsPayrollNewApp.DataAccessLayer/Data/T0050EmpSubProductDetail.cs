using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050EmpSubProductDetail
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ProductId { get; set; }

    public decimal SubProductId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal Rate { get; set; }

    public decimal FromLimit { get; set; }

    public decimal ToLimit { get; set; }

    public decimal LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040ProductMaster Product { get; set; } = null!;

    public virtual T0040SubProductMaster SubProduct { get; set; } = null!;
}
