using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAppraisalEmpPerfSummReview
{
    public decimal PsreviewId { get; set; }

    public decimal FkPsid { get; set; }

    public decimal FkEmployeeId { get; set; }

    public string PsComment { get; set; } = null!;

    public string CpComment { get; set; } = null!;

    public decimal? FkRatingId { get; set; }

    public byte? PsreviewSignoff { get; set; }

    public DateTime? PsreviewSignoffDate { get; set; }

    public byte IsEmpManager { get; set; }

    public decimal FkSettingId { get; set; }

    public decimal PsreviewCreatedBy { get; set; }

    public DateTime PsreviewCreatedDate { get; set; }

    public decimal? PsreviewModifyBy { get; set; }

    public DateTime? PsreviewModifyDate { get; set; }

    public virtual T0090HrmsAppraisalEmpPerformanceSummary FkPs { get; set; } = null!;

    public virtual T0040HrmsAppraisalSignoffSettingMaster FkSetting { get; set; } = null!;
}
