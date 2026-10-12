using FlorencaApi.Models;
using Microsoft.EntityFrameworkCore;

namespace FlorencaApi.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Agendamento> Agendamentos => Set<Agendamento>();
    public DbSet<Cupom> Cupons => Set<Cupom>();
    public DbSet<ComandaPedido> ComandasPedidos => Set<ComandaPedido>();
    public DbSet<Favorito> Favoritos => Set<Favorito>();
    public DbSet<FilaVirtual> FilaVirtual => Set<FilaVirtual>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Usuario>()
            .HasIndex(u => u.LoginUsuario)
            .IsUnique();

        modelBuilder.Entity<Cupom>()
            .HasIndex(c => c.CodigoCupom)
            .IsUnique();

        modelBuilder.Entity<Favorito>()
            .HasIndex(f => new { f.UsuarioId, f.PratoNome })
            .IsUnique();

        // Mantém os tipos DECIMAL(10,2) definidos no SQL Server.
        modelBuilder.Entity<ComandaPedido>()
            .Property(c => c.ValorTotal)
            .HasPrecision(10, 2);

        modelBuilder.Entity<Favorito>()
            .Property(f => f.Preco)
            .HasPrecision(10, 2);

        // As colunas created_at são preenchidas pelo DEFAULT GETDATE() do SQL Server.
        modelBuilder.Entity<Usuario>()
            .Property(u => u.CreatedAt)
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("GETDATE()");

        modelBuilder.Entity<Agendamento>()
            .Property(a => a.CreatedAt)
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("GETDATE()");

        modelBuilder.Entity<Cupom>()
            .Property(c => c.CreatedAt)
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("GETDATE()");

        modelBuilder.Entity<ComandaPedido>()
            .Property(c => c.CreatedAt)
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("GETDATE()");

        modelBuilder.Entity<Favorito>()
            .Property(f => f.CreatedAt)
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("GETDATE()");

        modelBuilder.Entity<FilaVirtual>()
            .Property(f => f.CreatedAt)
            .ValueGeneratedOnAdd()
            .HasDefaultValueSql("GETDATE()");
    }
}
