using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsAttributeMaster
{
    public decimal PaId { get; set; }

    public decimal CmpId { get; set; }

    public string? PaTitle { get; set; }

    public string? PaType { get; set; }

    public decimal? PaWeightage { get; set; }

    public int? PaSortNo { get; set; }

    public string? PaCategory { get; set; }

    public DateTime? PaEffectiveDate { get; set; }

    public string? PaDeptId { get; set; }

    public decimal? RefPaid { get; set; }

    public string? PaDesc { get; set; }

    public string? GradeId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0052HrmsAttributeFeedback> T0052HrmsAttributeFeedbacks { get; set; } = new List<T0052HrmsAttributeFeedback>();
}
