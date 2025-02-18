using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110UniformDispatchDetail
{
    public decimal UniDispId { get; set; }

    public decimal? UniAprId { get; set; }

    public decimal? UniReqAppId { get; set; }

    public decimal? UniReqAppDetailId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? DispatchCode { get; set; }

    public DateTime? DispatchDate { get; set; }

    public int? RefundInstallment { get; set; }

    public int? DeductionInstallment { get; set; }

    public DateTime? RefundStartDate { get; set; }

    public DateTime? DeductionStartDate { get; set; }

    public decimal? DispatchByEmpId { get; set; }

    public DateTime? SystemDatetime { get; set; }

    public string? Comments { get; set; }

    public string? IpAddress { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? DispatchByEmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0090UniformRequisitionApplication? UniReqApp { get; set; }

    public virtual T0095UniformRequisitionApplicationDetail? UniReqAppDetail { get; set; }
}
