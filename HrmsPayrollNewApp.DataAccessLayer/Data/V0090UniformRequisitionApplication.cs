using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090UniformRequisitionApplication
{
    public decimal UniReqAppId { get; set; }

    public decimal UniId { get; set; }

    public decimal UniReqAppDetailId { get; set; }

    public string? UniName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? SubBranchId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal? UniReqAppCode { get; set; }

    public DateTime? RequestDate { get; set; }

    public decimal? RequestedByEmpId { get; set; }

    public DateTime? SystemDate { get; set; }

    public int? UniPieces { get; set; }

    public decimal? UniFabricPrice { get; set; }

    public decimal? UniStitchingPrice { get; set; }

    public decimal? UniAmount { get; set; }

    public decimal? EmpId { get; set; }

    public string? Comments { get; set; }
}
