using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040CostCenter
{
    public decimal TallyCenterId { get; set; }

    public decimal TallyCatId { get; set; }

    public decimal CmpId { get; set; }

    public string CostCenter { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0080CostCenterDetail> T0080CostCenterDetails { get; set; } = new List<T0080CostCenterDetail>();

    public virtual ICollection<T9999SalaryExportCostDetail> T9999SalaryExportCostDetails { get; set; } = new List<T9999SalaryExportCostDetail>();

    public virtual T0040CostCategory TallyCat { get; set; } = null!;
}
