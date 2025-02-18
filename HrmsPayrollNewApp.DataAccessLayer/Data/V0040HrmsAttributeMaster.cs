using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040HrmsAttributeMaster
{
    public decimal PaId { get; set; }

    public string? PaTitle { get; set; }

    public string? PaType { get; set; }

    public string? PaTypeName { get; set; }

    public decimal? PaWeightage { get; set; }

    public int? PaSortNo { get; set; }

    public string? PaCategory { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? PaEffectiveDate { get; set; }

    public string PaDeptId { get; set; } = null!;

    public string? DeptName { get; set; }

    public string? PaDesc { get; set; }

    public string GradeName { get; set; } = null!;

    public string GradeId { get; set; } = null!;
}
