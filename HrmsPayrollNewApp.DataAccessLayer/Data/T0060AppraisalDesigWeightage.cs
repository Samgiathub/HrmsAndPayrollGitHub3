using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060AppraisalDesigWeightage
{
    public decimal DesigWeightageId { get; set; }

    public decimal CmpId { get; set; }

    public decimal DesigId { get; set; }

    public decimal? EkpaWeightage { get; set; }

    public decimal? SaWeightage { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? PaWeightage { get; set; }

    public decimal? PoAWeightage { get; set; }

    public bool? EkpaRestrictWeightage { get; set; }

    public bool? SaRestrictWeightage { get; set; }
}
