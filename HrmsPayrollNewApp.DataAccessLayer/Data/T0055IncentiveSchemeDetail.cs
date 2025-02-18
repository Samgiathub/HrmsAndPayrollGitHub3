using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055IncentiveSchemeDetail
{
    public decimal SchemeId { get; set; }

    public decimal RowId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? BranchId { get; set; }

    public virtual T0050IncentiveScheme Scheme { get; set; } = null!;
}
