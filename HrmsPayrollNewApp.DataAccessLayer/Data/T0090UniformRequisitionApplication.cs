using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090UniformRequisitionApplication
{
    public decimal UniReqAppId { get; set; }

    public decimal UniId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? UniReqAppCode { get; set; }

    public DateTime? RequestDate { get; set; }

    public decimal? RequestedByEmpId { get; set; }

    public DateTime? SystemDate { get; set; }

    public string? IpAddress { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? RequestedByEmp { get; set; }

    public virtual ICollection<T0095UniformRequisitionApplicationDetail> T0095UniformRequisitionApplicationDetails { get; set; } = new List<T0095UniformRequisitionApplicationDetail>();

    public virtual ICollection<T0100UniformRequisitionApproval> T0100UniformRequisitionApprovals { get; set; } = new List<T0100UniformRequisitionApproval>();

    public virtual ICollection<T0110UniformDispatchDetail> T0110UniformDispatchDetails { get; set; } = new List<T0110UniformDispatchDetail>();

    public virtual T0040UniformMaster Uni { get; set; } = null!;
}
