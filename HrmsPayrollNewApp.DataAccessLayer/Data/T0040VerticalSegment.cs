using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040VerticalSegment
{
    public decimal VerticalId { get; set; }

    public decimal? CmpId { get; set; }

    public string? VerticalCode { get; set; }

    public string? VerticalName { get; set; }

    public string? VerticalDescription { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0050SubVertical> T0050SubVerticals { get; set; } = new List<T0050SubVertical>();

    public virtual ICollection<T0052HrmsRecruitmentRequestApproval> T0052HrmsRecruitmentRequestApprovals { get; set; } = new List<T0052HrmsRecruitmentRequestApproval>();

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinals { get; set; } = new List<T0060ResumeFinal>();
}
