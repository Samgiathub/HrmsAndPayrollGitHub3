using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080CostCenterDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal CostCatId { get; set; }

    public decimal CostCenterId { get; set; }

    public decimal SalTranExpId { get; set; }

    public decimal Amount { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040CostCategory CostCat { get; set; } = null!;

    public virtual T0040CostCenter CostCenter { get; set; } = null!;
}
