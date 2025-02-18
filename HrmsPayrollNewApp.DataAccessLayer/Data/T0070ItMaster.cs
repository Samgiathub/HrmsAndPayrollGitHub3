using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0070ItMaster
{
    public decimal ItId { get; set; }

    public decimal CmpId { get; set; }

    public string? ItName { get; set; }

    public string ItAlias { get; set; } = null!;

    public decimal ItMaxLimit { get; set; }

    public string ItFlag { get; set; } = null!;

    public int ItLevel { get; set; }

    public int ItDefId { get; set; }

    public byte ItIsActive { get; set; }

    public decimal? ItParentId { get; set; }

    public decimal? AdId { get; set; }

    public decimal? RimbId { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public byte ItMainGroup { get; set; }

    public byte ItDeclarationReq { get; set; }

    public string? ItDocName { get; set; }

    public byte? ItIsHeader { get; set; }

    public byte? ItIsAtthComp { get; set; }

    public byte? ItIsDetails { get; set; }

    public byte ItIsPerquisite { get; set; }

    public string? AdString { get; set; }

    public decimal ExemptPercent { get; set; }

    public virtual T0050AdMaster? Ad { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0070ItMaster> InverseItParent { get; set; } = new List<T0070ItMaster>();

    public virtual T0070ItMaster? ItParent { get; set; }

    public virtual T0011Login? Login { get; set; }

    public virtual T0055Reimbursement? Rimb { get; set; }

    public virtual ICollection<T0100ItDeclaration> T0100ItDeclarations { get; set; } = new List<T0100ItDeclaration>();

    public virtual ICollection<T0100ItFormDesign> T0100ItFormDesigns { get; set; } = new List<T0100ItFormDesign>();
}
