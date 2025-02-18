using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TypeMaster
{
    public decimal TypeId { get; set; }

    public decimal CmpId { get; set; }

    public string? TypeName { get; set; }

    public decimal? TypeDisNo { get; set; }

    public decimal? TypeDefId { get; set; }

    public decimal EncashmentRate { get; set; }

    public string? TypeCode { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0010HrCompReq> T0010HrCompReqs { get; set; } = new List<T0010HrCompReq>();

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0052HrmsRecruitmentRequestApproval> T0052HrmsRecruitmentRequestApprovals { get; set; } = new List<T0052HrmsRecruitmentRequestApproval>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0090AppMaster> T0090AppMasters { get; set; } = new List<T0090AppMaster>();
}
