using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050SaSubCriterion
{
    public decimal SappCriteriaId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SapparisalId { get; set; }

    public string SappCriteriaContent { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040SelfAppraisalMaster Sapparisal { get; set; } = null!;
}
