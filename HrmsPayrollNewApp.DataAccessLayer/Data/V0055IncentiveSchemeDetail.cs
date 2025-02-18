using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055IncentiveSchemeDetail
{
    public decimal SchemeId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? BranchId { get; set; }
}
