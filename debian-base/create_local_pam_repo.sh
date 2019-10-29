# Install dpkg-dev for dpkg-scanpackages
apt-get update
apt-get install --no-install-recommends -y dpkg-dev
rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Purge debug symbol packages.
rm *dbgsym*.deb

# Create a Packages.gz file for apt/dselect
dpkg-scanpackages . | gzip -9c > Packages.gz

#-------------------------------------------------------------------------------
# APT-PINNING

# Pin local repo as preferred source by listing it first
sed -i "1ideb [trusted=yes] file:${PWD} /" /etc/apt/sources.list

# Pin package version to that in local repo
cat >> /etc/apt/preferences << EOF
Package: *  
Pin: origin ""  
Pin-Priority: 999
EOF