using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0060AppraisalDesigWeightage
{
    public decimal? DesigWeightageId { get; set; }

    public decimal EkpaWeightage { get; set; }

    public decimal SaWeightage { get; set; }

    public decimal CmpId { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal DesigId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? Expr1 { get; set; }

    public decimal? Expr2 { get; set; }

    public decimal PaWeightage { get; set; }

    public DateTime? Expr3 { get; set; }

    public decimal PoAWeightage { get; set; }

    public bool EkpaRestrictWeightage { get; set; }

    public bool SaRestrictWeightage { get; set; }
}
