using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100UniformRequisitionApproval
{
    public decimal UniAprId { get; set; }

    public decimal? UniReqAppId { get; set; }

    public decimal? UniReqAppDetailId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? ApprovalCode { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public string? ApproveStatus { get; set; }

    public decimal? ApprovedByEmpId { get; set; }

    public DateTime? SystemDatetime { get; set; }

    public string? Comments { get; set; }

    public int? UniPieces { get; set; }

    public decimal? UniFabricPrice { get; set; }

    public decimal? UniStitchingPrice { get; set; }

    public decimal? UniAmount { get; set; }

    public string? IpAddress { get; set; }

    public virtual T0080EmpMaster? ApprovedByEmp { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0090UniformRequisitionApplication? UniReqApp { get; set; }

    public virtual T0095UniformRequisitionApplicationDetail? UniReqAppDetail { get; set; }
}
