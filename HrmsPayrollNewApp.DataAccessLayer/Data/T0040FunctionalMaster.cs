using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040FunctionalMaster
{
    public decimal TypeId { get; set; }

    public decimal CmpId { get; set; }

    public string TypeName { get; set; } = null!;

    public string Description { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
