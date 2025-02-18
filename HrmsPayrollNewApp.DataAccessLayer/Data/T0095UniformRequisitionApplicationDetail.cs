using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095UniformRequisitionApplicationDetail
{
    public decimal UniReqAppDetailId { get; set; }

    public decimal? UniReqAppId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public int? UniPieces { get; set; }

    public decimal? UniFabricPrice { get; set; }

    public decimal? UniStitchingPrice { get; set; }

    public decimal? UniAmount { get; set; }

    public string? Comments { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual ICollection<T0100UniformRequisitionApproval> T0100UniformRequisitionApprovals { get; set; } = new List<T0100UniformRequisitionApproval>();

    public virtual ICollection<T0110UniformDispatchDetail> T0110UniformDispatchDetails { get; set; } = new List<T0110UniformDispatchDetail>();

    public virtual T0090UniformRequisitionApplication? UniReqApp { get; set; }
}
