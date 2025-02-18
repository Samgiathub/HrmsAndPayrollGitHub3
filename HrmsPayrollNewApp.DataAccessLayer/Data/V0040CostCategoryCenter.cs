using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040CostCategoryCenter
{
    public decimal TallyCenterId { get; set; }

    public decimal TallyCatId { get; set; }

    public decimal CmpId { get; set; }

    public string CostCenter { get; set; } = null!;

    public string CostCategory { get; set; } = null!;
}
