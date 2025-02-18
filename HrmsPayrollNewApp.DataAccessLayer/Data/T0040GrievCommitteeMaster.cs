using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040GrievCommitteeMaster
{
    public int GcId { get; set; }

    public string? ComName { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public int? CmpId { get; set; }

    public string? StateId { get; set; }

    public string? DistrictId { get; set; }

    public string? TehsilId { get; set; }

    public string? BranchId { get; set; }

    public string? VerticalId { get; set; }

    public string? SubVerticalId { get; set; }

    public string? BusinessSgmtId { get; set; }

    public int? ChairpersonId { get; set; }

    public int? NodelHrId { get; set; }

    public string? CommitteeMemId { get; set; }

    public int? IsActive { get; set; }

    public DateTime? Cdtm { get; set; }

    public DateTime? Udtm { get; set; }

    public string? Log { get; set; }

    public string? BranchName { get; set; }

    public string? CommMemText { get; set; }
}
