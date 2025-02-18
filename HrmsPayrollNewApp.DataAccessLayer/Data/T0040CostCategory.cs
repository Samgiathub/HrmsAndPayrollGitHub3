using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040CostCategory
{
    public decimal TallyCatId { get; set; }

    public decimal CmpId { get; set; }

    public string CostCategory { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0040CostCenter> T0040CostCenters { get; set; } = new List<T0040CostCenter>();

    public virtual ICollection<T0080CostCenterDetail> T0080CostCenterDetails { get; set; } = new List<T0080CostCenterDetail>();
}
