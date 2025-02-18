using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095UniformRequisitionApplicationDatum
{
    public decimal UniReqAppDetailId { get; set; }

    public decimal UniReqAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public int? UniPieces { get; set; }

    public decimal? UniFabricPrice { get; set; }

    public decimal? UniStitchingPrice { get; set; }

    public decimal? UniAmount { get; set; }

    public decimal UniId { get; set; }

    public decimal? UniReqAppCode { get; set; }

    public DateTime? RequestDate { get; set; }

    public decimal? RequestedByEmpId { get; set; }

    public DateTime? SystemDate { get; set; }
}
