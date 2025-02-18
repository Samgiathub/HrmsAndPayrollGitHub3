using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050PieceTran
{
    public decimal PieceTranId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? ProductName { get; set; }

    public string? SubProductName { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? ProductId { get; set; }

    public decimal? SubProductId { get; set; }

    public decimal? PieceTransCount { get; set; }

    public DateTime? PieceTransDate { get; set; }
}
