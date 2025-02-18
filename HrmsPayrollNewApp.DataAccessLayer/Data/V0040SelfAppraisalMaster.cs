using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040SelfAppraisalMaster
{
    public decimal SapparisalId { get; set; }

    public decimal? CmpId { get; set; }

    public string? SapparisalContent { get; set; }

    public int? Sweight { get; set; }

    public int? SappraisalSort { get; set; }

    public string? SdeptId { get; set; }

    public string? DeptName { get; set; }

    public string? Category { get; set; }

    public string? Branch { get; set; }

    public int? SisMandatory { get; set; }

    public int? Stype { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal Skpaweight { get; set; }
}
