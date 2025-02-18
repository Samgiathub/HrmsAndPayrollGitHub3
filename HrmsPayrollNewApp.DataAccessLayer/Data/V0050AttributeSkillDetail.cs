using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050AttributeSkillDetail
{
    public string? EffectDate { get; set; }

    public decimal SkillWeightage { get; set; }

    public decimal AttrWeightage { get; set; }

    public string? DesigName { get; set; }

    public decimal? DesigId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal Type { get; set; }

    public string? DeptName { get; set; }

    public decimal? DeptId { get; set; }
}
