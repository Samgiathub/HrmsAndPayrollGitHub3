using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpSkillAttrAssign
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime EffectDate { get; set; }

    public decimal? DesigId { get; set; }

    public decimal SkillWeightage { get; set; }

    public decimal AttrWeightage { get; set; }

    public decimal Type { get; set; }

    public decimal? DeptId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0110AttributeWeightage> T0110AttributeWeightages { get; set; } = new List<T0110AttributeWeightage>();

    public virtual ICollection<T0110SkillWeightage> T0110SkillWeightages { get; set; } = new List<T0110SkillWeightage>();
}
